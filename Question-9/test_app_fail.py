import pytest
from app import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_home_status_code(client):
    """This test ALWAYS FAILS on purpose to demonstrate pipeline failure catching."""
    response = client.get("/")
    # DELIBERATELY WRONG: expecting 404 instead of 200
    assert response.status_code == 404, "DELIBERATE FAILURE: This test is intentionally wrong!"


def test_home_response_body(client):
    """This test also FAILS on purpose."""
    response = client.get("/")
    # DELIBERATELY WRONG expected string
    assert response.data.decode("utf-8") == "WRONG EXPECTED RESPONSE — this will fail!"
