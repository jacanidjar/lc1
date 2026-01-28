import pytest
import json
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_hello_endpoint(client):
    """Test the root endpoint returns correct JSON structure"""
    rv = client.get('/')
    assert rv.status_code == 200
    json_data = rv.get_json()
    
    assert "message" in json_data
    assert json_data["message"] == "Hello World"
    assert "candidate" in json_data
    assert "environment" in json_data
    assert "commit_id" in json_data

def test_health_endpoint(client):
    """Test the health check endpoint"""
    rv = client.get('/health')
    assert rv.status_code == 200
    json_data = rv.get_json()
    assert json_data["status"] == "healthy"
