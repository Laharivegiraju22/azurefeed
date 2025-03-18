from setuptools import setup

setup(
    name="flask_app",
    version="7.0.0",
    py_modules=["app"],
    install_requires=[
        "flask"
    ],
    entry_points={
        "console_scripts": [
            "flask-app=app:main"
        ]
    },
)
