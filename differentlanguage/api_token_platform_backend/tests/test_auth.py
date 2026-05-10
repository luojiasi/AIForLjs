def test_register(client):
    resp = client.post("/auth/register", json={"username": "alice", "password": "secret123"})
    assert resp.status_code == 200
    data = resp.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"


def test_register_duplicate(client):
    client.post("/auth/register", json={"username": "bob", "password": "secret123"})
    resp = client.post("/auth/register", json={"username": "bob", "password": "secret123"})
    assert resp.status_code == 409


def test_login(client):
    client.post("/auth/register", json={"username": "charlie", "password": "mypassword"})
    resp = client.post("/auth/login", json={"username": "charlie", "password": "mypassword"})
    assert resp.status_code == 200
    data = resp.json()
    assert "access_token" in data


def test_login_invalid(client):
    resp = client.post("/auth/login", json={"username": "nobody", "password": "wrong"})
    assert resp.status_code == 401


def test_create_and_list_api_keys(client, auth_headers):
    headers, _ = auth_headers
    # Create
    resp = client.post("/auth/api-keys", json={"name": "prod key"}, headers=headers)
    assert resp.status_code == 200
    data = resp.json()
    assert "raw_key" in data
    assert data["raw_key"].startswith("atp_")

    # List
    resp = client.get("/auth/api-keys", headers=headers)
    assert resp.status_code == 200
    keys = resp.json()
    assert len(keys) >= 1
    assert keys[0]["name"] == "test key"


def test_revoke_api_key(client, auth_headers):
    headers, _ = auth_headers
    keys = client.get("/auth/api-keys", headers=headers).json()
    key_id = keys[0]["id"]
    resp = client.delete(f"/auth/api-keys/{key_id}", headers=headers)
    assert resp.status_code == 200

    # 验证已撤销
    keys = client.get("/auth/api-keys", headers=headers).json()
    assert keys[0]["is_active"] is False
