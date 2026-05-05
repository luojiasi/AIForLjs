"""
Python Code Executor Server
Local HTTP server for executing Python code snippets from the Flutter tutorial app.

Usage:
    pip install flask
    python server.py

The server runs on http://localhost:8765
POST /execute  - Execute Python code
GET  /health   - Health check
"""

import sys
import io
import traceback
import subprocess
import tempfile
import os
import signal
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

EXECUTION_TIMEOUT = 30  # seconds


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({
        'status': 'ok',
        'python_version': sys.version,
        'executable': sys.executable,
    })


@app.route('/execute', methods=['POST'])
def execute():
    """Execute Python code and return stdout/stderr."""
    data = request.get_json(silent=True) or {}
    code = data.get('code', '').strip()
    timeout = min(int(data.get('timeout', EXECUTION_TIMEOUT)), 60)

    if not code:
        return jsonify({'output': '', 'error': 'No code provided', 'success': False})

    # Write code to a temp file and execute in subprocess for isolation
    tmp = tempfile.NamedTemporaryFile(
        mode='w', suffix='.py', delete=False, encoding='utf-8'
    )
    try:
        tmp.write(code)
        tmp.close()

        proc = subprocess.run(
            [sys.executable, tmp.name],
            capture_output=True,
            text=True,
            timeout=timeout,
        )

        stdout = proc.stdout or ''
        stderr = proc.stderr or ''

        output_parts = []
        if stdout:
            output_parts.append(stdout.rstrip())
        if stderr:
            output_parts.append(stderr.rstrip())

        return jsonify({
            'output': '\n'.join(output_parts),
            'success': proc.returncode == 0 and not stderr,
            'exit_code': proc.returncode,
        })

    except subprocess.TimeoutExpired:
        return jsonify({
            'output': '',
            'error': f'代码执行超时（{timeout}秒），可能存在无限循环或网络阻塞。',
            'success': False,
        })
    except Exception as e:
        return jsonify({
            'output': '',
            'error': f'执行失败: {str(e)}',
            'success': False,
        })
    finally:
        try:
            os.unlink(tmp.name)
        except OSError:
            pass


if __name__ == '__main__':
    print(f'Python Executor Server starting on http://localhost:8765')
    print(f'Python version: {sys.version}')
    print(f'Executable: {sys.executable}')
    print(f'Timeout: {EXECUTION_TIMEOUT}s per request')
    print('Press Ctrl+C to stop')
    app.run(host='127.0.0.1', port=8765, debug=False)
