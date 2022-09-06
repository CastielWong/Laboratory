
- [REST](#rest)
  - [Check](#check)
- [Reference](#reference)


This is used to explore Flask stuff.

Flask is a lightweight WSGI web application framework. It is designed to make getting started quick and easy, with the ability to scale up to complex applications.

To create a separate python environment for the exploration, run bash scripts below:

```sh
pyenv install {version}
pyenv virtualenv -p python{3.x} {version} lab_flask
pyenv local lab_flask
```

A model is the internal representation of an entity, whereas a resource is the external
representation of an entity.


## REST

A basic example of HTTP Verbs:

| Verb | Meaning | Example |
| --- | --- | --- |
| GET | read, retrieve something | GET /item/1 |
| POST | create, receive data, and use it | POST /item |
| PUT | update, make sure something is there | PUT /item |
| DELETE | delete, remove something | DELETE /item/1 |

RESTful API are developed, all API endpoints available are:

| Endpoint | Verb | HEADER | Param | Description |
| --- | --- | --- | --- | --- |
| /register | POST | | username, password | Register a user |
| /login | POST | | username, password | Retrieve user's credential |
| /logout | POST | Authorization | | Revoke user's credential |
| /user/<user_id> | GET | Authorization | | Retrieve a user |
| /user/<user_id> | DELETE | Authorization | | Delete a user |
| /items | GET | | | List all items |
| /item/<name> | GET | Authorization | | Retrieve an item |
| /item/<name> | POST | Authorization | price, store_id | Create an item |
| /item/<name> | DELETE | Authorization | | Delete an item |
| /item/<name> | PUT | Authorization | price, store_id | Update an item |
| /stores | GET | | | List all stores |
| /store/<name> | GET | Authorization | | Retrieve a store |
| /store/<name> | POST | Authorization | | Create a store |
| /store/<name> | DELETE | Authorization | | Delete a store |

"http://127.0.0.1:5000" is the default URL.

__Flask-JWT-Extended__ is applied to take care of the authentication.

Note that if Docker Desktop is used on Mac, subnet IPs are [inaccessible](https://docs.docker.com/desktop/networking/#i-cannot-ping-my-containers):
> Docker Desktop can’t route traffic to Linux containers. However if you’re a Windows user, you can ping the Windows containers.

### Check
There are ways to check if the application is working properly:
- [REST Client](https://marketplace.visualstudio.com/items?itemName=humao.rest-client)
- [Postman](https://www.postman.com/postman/)

VS Code's plugin - REST Client is recommended.
File "api.test" is prepared for the checking.


## Reference
- Flask Website: https://palletsprojects.com/p/flask/
- REST APIs with Flask and Python: https://www.udemy.com/course/rest-api-flask-and-python/
- General structure of the project: https://arac.tecladocode.com/1_structure_of_api/1_7_resources_user.html#userlogout
- Getting Started with Alpine: http://containertutorials.com/alpine/get_started.html
