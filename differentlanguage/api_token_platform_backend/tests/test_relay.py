def test_relay_no_auth(client):
    resp = client.post("/v1/chat/completions", json={
        "model": "gpt-4o",
        "messages": [{"role": "user", "content": "Hello"}],
    })
    assert resp.status_code == 401


def test_relay_with_invalid_key(client):
    resp = client.post(
        "/v1/chat/completions",
        json={"model": "gpt-4o", "messages": [{"role": "user", "content": "Hi"}]},
        headers={"Authorization": "Bearer atp_invalidkey1234567890"},
    )
    assert resp.status_code == 401


def test_relay_unknown_vendor(client, auth_headers):
    headers, _ = auth_headers
    resp = client.post(
        "/v1/chat/completions",
        json={"model": "gpt-4o", "messages": [{"role": "user", "content": "Hi"}]},
        headers=headers,
    )
    # 没有配置厂商 key，应返回 400（no active API key configured）
    assert resp.status_code in (400, 502)


def test_health_check(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.json()["status"] == "ok"


def test_usage_stats(client, auth_headers):
    headers, _ = auth_headers
    resp = client.get("/usage/stats", headers=headers)
    assert resp.status_code == 200
    data = resp.json()
    assert "total_requests" in data
    assert "total_tokens" in data
    assert "quotas" in data
    assert "recent_requests" in data


def test_supported_vendors(client):
    resp = client.get("/admin/vendors/supported")
    assert resp.status_code == 200
    vendors = resp.json()
    names = [v["vendor_name"] for v in vendors]
    assert "openai" in names
    assert "anthropic" in names
