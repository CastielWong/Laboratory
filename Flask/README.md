
This is used to explore Flask stuff.

To create a separate python environment for the exploration, run bash scripts below:

```sh
pyenv install {version}
pyenv virtualenv -p python{3.x} {version} lab_flask
pyenv local lab_flask
```

A basic example of HTTP Verbs:

| Verb | Meaning | Example |
| GET | read, retrieve something | GET /item/1 |
| POST | create, receive data, and use it | POST /item |
| PUT | update, make sure something is there | PUT /item |
| DELETE | delete, remove something | DELETE /item/1 |

[Postman](https://www.postman.com/postman/) is good for testing to check if the application is
working properly. Remember to set _Headers_ to ("Content-Type", "application/json") for POST action.

A model is the internal representation of an entity, whereas a resource is the external
representation of an entity.


## Authentication

Run `pip install flask-JWT` to install Flask-JWT for JSON Web Token. Grasp JWT from "localhost:5000/auth"
via POST with corresponding user and password, then get the access token to perform other action with
header ("Authorization", "JWT {token}").


## Reference

- REST APIs with Flask and Python: https://www.udemy.com/course/rest-api-flask-and-python/
