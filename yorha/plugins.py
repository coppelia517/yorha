# -*- coding: utf-8 -*-
import pytest


def pytest_addoption(parser) -> None:
    """ pytest add-on
    """
    group = parser.getgroup('yorha')
    group.addoption('--foo',
                    action='store',
                    dest='dest_foo',
                    default='2019',
                    help='Set the value for the fixture "bar".')

    parser.addini('HELLO', 'Dummy pytest.ini setting')


@pytest.fixture
def bar(request):
    """ pytest fixture
    """
    return request.config.option.dest_foo
