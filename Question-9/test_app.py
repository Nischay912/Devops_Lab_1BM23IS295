import pytest
from app import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_home_status_code(client):
    """Test that the home route returns HTTP 200."""
    response = client.get("/")
    assert response.status_code == 200


def test_home_response_body(client):
    """Test that the home route returns the correct response body."""
    response = client.get("/")
    assert response.data.decode("utf-8") == "Hello from Flask CI/CD Pipeline!"


def test_health_route(client):
    """Test that the health route returns UP status."""
    response = client.get("/health")
    assert response.status_code == 200
