
## Showing Session Endpoint

### Get a showing session

#### Request
  
  GET sessions/:session_id

#### Response

##### when session.status is not "ongoing"
  
200 OK

```javascript
{
    "id": 6,
    "status": "failed"
}
```

##### when session.status is ongoing

200 OK

```javascript
{
    "id": 1,
    "status": "ongoing",
    "attempts_remaining": null,
    "showing": {
        "id": 1,
        "start_time": "2015-03-07T08:00:00.000Z",
        "end_time": "2015-03-09T18:03:17.280Z",
        "is_graded": false,
        "max_attempts": null,
        "display_name": null,
        "scenario": {
            "id": 2,
            "name": "Here she is",
            "description": "The scenario name",
            "archived": false,
            "root_node_id": 19,
            "locked": null
        },
        "course": {
            "id": 1,
            "title": "yo bro",
            "active": true,
            "access_code": "ecca9811d8e524e80afc"
        }
    },
    "node": {
        "id": 1,
        "title": "My Root node",
        "body": "State what you would do if you were not a chemist?",
        "is_start": true,
        "is_goal": false,
        "is_failure": false,
        "requires_justification": true,
        "choices": [
            {
                "id": 33,
                "text": null,
                "node_id": 1,
                "to_node_id": 2
            },
            {
                "id": 34,
                "text": null,
                "node_id": 1,
                "to_node_id": 3
            }
        ],
        "asset": {
            "id": 2,
            "image": "/system/assets/images/000/000/002/medium/Photo_on_3-6-15_at_4.01_PM.jpg?1425838587",
            "thumbnail": "/system/assets/images/000/000/002/thumb/Photo_on_3-6-15_at_4.01_PM.jpg?1425838587"
        }
    }
}
```

401 Unauthorized
User doesn't belong to session.

404 Not Found
No session with that id

### Create a showing session

#### Request

	POST showings/:id/session

#### Payload

  None

#### Response

200 OK

when status is not 'ongoing'

```javascript
{
    "id": 6,
    "status": "failed"
}
```

when status is 'ongoing'

201 OK

```javascript
{
    "id": 1,
    "status": "ongoing",
    /* below only displayed if showing status is ongoing */
    "attempts_remaining": null,
    "showing": {
        "id": 1,
        "start_time": "2015-03-07T08:00:00.000Z",
        "end_time": "2015-03-09T18:03:17.280Z",
        "is_graded": false,
        "max_attempts": null,
        "display_name": null,
        "scenario": {
            "id": 2,
            "name": "Here she is",
            "description": "The scenario name",
            "archived": false,
            "root_node_id": 19,
            "locked": null
        },
        "course": {
            "id": 1,
            "title": "yo bro",
            "active": true,
            "access_code": "ecca9811d8e524e80afc"
        }
    },
    "node": {
        "id": 1,
        "title": "My Root node",
        "body": "State what you would do if you were not a chemist?",
        "is_start": true,
        "is_goal": false,
        "is_failure": false,
        "requires_justification": true,
        "choices": [
            {
                "id": 33,
                "text": null,
                "node_id": 1,
                "to_node_id": 2
            },
            {
                "id": 34,
                "text": null,
                "node_id": 1,
                "to_node_id": 3
            }
        ],
        "asset": {
            "id": 2,
            "image": "/system/assets/images/000/000/002/medium/Photo_on_3-6-15_at_4.01_PM.jpg?1425838587",
            "thumbnail": "/system/assets/images/000/000/002/thumb/Photo_on_3-6-15_at_4.01_PM.jpg?1425838587"
        }
    }
}
```

  401 Unauthorized
  if user not enrolled in showing attempted to be created

  `No Payload`

  404 Not Found
  if showing could not be found

  422 Unprocessable Entity
  if showing has expired, if session for showing with user already exists

### Make a decision
  
  Hit this endpoint when a user is selects a choice at a given node.
  It will log the decision and return back the node data for the selected choice.

#### Request

	POST sessions/:session_id/decide

#### Payload

```javascript
  {
    to_node_id: <node_chosen>, 
    justification: "..."  //if required
  }
```

#### Response

when status is not 'ongoing'

```javascript
{
    "id": 6,
    "status": "failed"
}
```

when status is ongoing

 Contains the next node and latest status of the session
 session status codes:
    failed: user has used all attempts and failed
    completed: scenario is completed
    expired: showing has expired since last read
    ongoing: just ongoing

201 OK

```javascript
{
    "id": 1,
    "status": "ongoing",
    "attempts_remaining": null,
    "showing": {
        "id": 1,
        "start_time": "2015-03-07T08:00:00.000Z",
        "end_time": "2015-03-09T18:03:17.280Z",
        "is_graded": false,
        "max_attempts": null,
        "display_name": null,
        "scenario": {
            "id": 2,
            "name": "Here she is",
            "description": "The scenario name",
            "archived": false,
            "root_node_id": 19,
            "locked": null
        },
        "course": {
            "id": 1,
            "title": "yo bro",
            "active": true,
            "access_code": "ecca9811d8e524e80afc"
        }
    },
    "node": {
        "id": 1,
        "title": "My Root node",
        "body": "State what you would do if you were not a chemist?",
        "is_start": true,
        "is_goal": false,
        "is_failure": false,
        "requires_justification": true,
        "choices": [
            {
                "id": 33,
                "text": null,
                "node_id": 1,
                "to_node_id": 2
            },
            {
                "id": 34,
                "text": null,
                "node_id": 1,
                "to_node_id": 3
            }
        ],
        "asset": {
            "id": 2,
            "image": "/system/assets/images/000/000/002/medium/Photo_on_3-6-15_at_4.01_PM.jpg?1425838587",
            "thumbnail": "/system/assets/images/000/000/002/thumb/Photo_on_3-6-15_at_4.01_PM.jpg?1425838587"
        }
    }
}
```

  401 Unauthorized
  - if user does not belong to session sent

  422 Unprocessable Entity
  - if choice isn't valid given current node
  - if no justification provided when required

  404 Not Found
  - if session status is not 'ongoing' ie. it is 'completed' or 'failed' or does not exist

### Restart

  Use to return the user back to the start node after reaching a failure.

#### Request

	POST sessions/:session_id/restart

#### Payload

  {
    "session_id": 1
  }

#### Response

  Returns the showing session and the root node

200 OK

```javascript
{
    "id": 1,
    "status": "ongoing",
    "attempts_remaining": null,
    "showing": {
        "id": 1,
        "start_time": "2015-03-07T08:00:00.000Z",
        "end_time": "2015-03-09T18:03:17.280Z",
        "is_graded": false,
        "max_attempts": null,
        "display_name": null,
        "scenario": {
            "id": 2,
            "name": "Here she is",
            "description": "The scenario name",
            "archived": false,
            "root_node_id": 19,
            "locked": null
        },
        "course": {
            "id": 1,
            "title": "yo bro",
            "active": true,
            "access_code": "ecca9811d8e524e80afc"
        }
    },
    "node": {
        "id": 1,
        "title": "My Root node",
        "body": "State what you would do if you were not a chemist?",
        "is_start": true,
        "is_goal": false,
        "is_failure": false,
        "requires_justification": true,
        "choices": [
            {
                "id": 33,
                "text": null,
                "node_id": 1,
                "to_node_id": 2
            },
            {
                "id": 34,
                "text": null,
                "node_id": 1,
                "to_node_id": 3
            }
        ],
        "asset": {
            "id": 2,
            "image": "/system/assets/images/000/000/002/medium/Photo_on_3-6-15_at_4.01_PM.jpg?1425838587",
            "thumbnail": "/system/assets/images/000/000/002/thumb/Photo_on_3-6-15_at_4.01_PM.jpg?1425838587"
        }
    }
}
```

  401 Unauthorized
  if user not enrolled in showing attempted to be created

  `No Payload`

  400 Bad Request
  if user not at a failure node and attempts to restart

  404 Not Found
  if showing is no longer of status of 'ongoing' or could not be found
