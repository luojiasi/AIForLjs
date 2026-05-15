export function useMarkdown() {
  function escapeHtml(text: string): string {
    return text
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
  }

  const PLACEHOLDER = '\x00CODE\x00'

  function render(text: string): string {
    let html = escapeHtml(text)

    // Protect code blocks from subsequent regex passes
    const codeBlocks: string[] = []
    html = html.replace(
      /```(\w*)\n([\s\S]*?)```/g,
      (_: string, lang: string, code: string) => {
        const langLabel = lang
          ? `<div class="code-lang">${escapeHtml(lang)}</div>`
          : ''
        const block = `<div class="code-block-wrapper">${langLabel}<pre><code>${code.trimEnd()}</code></pre></div>`
        codeBlocks.push(block)
        return PLACEHOLDER
      },
    )

    // inline code `...`
    html = html.replace(
      /`([^`]+)`/g,
      '<code class="inline-code">$1</code>',
    )

    // bold **...**
    html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')

    // italic *...*
    html = html.replace(/\*([^*]+)\*/g, '<em>$1</em>')

    // headers
    html = html.replace(/^#### (.+)$/gm, '<h4>$1</h4>')
    html = html.replace(/^### (.+)$/gm, '<h3>$1</h3>')
    html = html.replace(/^## (.+)$/gm, '<h2>$1</h2>')
    html = html.replace(/^# (.+)$/gm, '<h1>$1</h1>')

    // unordered lists
    html = html.replace(/^- (.+)$/gm, '<li>$1</li>')
    html = html.replace(/(<li>.*<\/li>)/s, '<ul>$1</ul>')

    // paragraphs (double newline)
    html = html.replace(/\n\n/g, '</p><p>')

    // single newline → <br>
    html = html.replace(/\n/g, '<br>')

    // Restore code blocks
    let idx = 0
    html = html.replace(new RegExp(PLACEHOLDER, 'g'), () => codeBlocks[idx++])

    return `<p>${html}</p>`
  }

  return { render }
}
