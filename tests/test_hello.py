import mock
import pytest

import sys
sys.modules['pyodbc'] = mock.MagicMock()  # noqa: E402

import hello


@pytest.fixture
def client():
    hello.app.config['TESTING'] = True

    with hello.app.test_client() as client:
        yield client


def test_root(client):
    rv = client.get('/')
    assert b'Hello World' in rv.data
