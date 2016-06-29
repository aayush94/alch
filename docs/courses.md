## Courses Endpoint

### Get courses for a user

#### Request

  GET /courses 
  Returns all active courses for the current logged in user. Includes access_code if user is instructor and is enrolled in class.

#### Response
  
  ```javascript
  {
    "id": 5,
    "title": "Chem 300",
    "access_code": "2134mlsjldk3"
  }
  ```

### Create a course

#### Request

  POST /courses

#### Payload
  Optionally specify 'active': false, default is true 

  ```javascript
  {
    "title": "hello"
  }
  ```

### Response

  `200, 401, 422` 

### Update a course

#### Request

  PUT/PATCH /courses/:course_id

#### Payload

  ```javascript
  {
    "id": 5,
    "title": "new title"
  }
  ```

### Response

  `200, 401, 422` 


### Enroll in a course

### Request

  PATCH/PUT /courses/:course_id/enroll 

### Payload

  ```javascript
  {
    "access_code": "34lk2j34234"
  }
  ```

### Response

  `200, 422, 401, 404` 



### Create a showing for a course

#### Request

	POST /courses/{course_id}/showings.json

#### Example

	POST /courses/1/showings.json

#### Payload

	{
	    "scenario_id" : 1,
	    "start_time": "2015-01-01",
	    "end_time": "2015-04-15"
	}

* Parameters:
	* `scenario_id` is required. The ID of the scenario the showing belongs to.
	* `course_id` is required. The ID of the course the showing belongs to.
	* `start_time` is required. The time the showing begins.
	* `end_time` is required. The time the showing ends.
* Note that an instructor must be enrolled in the course they are trying to create a showing for.

#### Response

	201 Created
	
	{
		"id": 5,
		"start_time": "2015-01-01T00:00:00.000Z",
		"end_time": "2015-04-15T00:00:00.000Z",
		"scenario": {
			"id": 1,
			"name": "My Scenario",
			"description": "My Scenario Description",
			"archived": false,
			"root_node_id": 1
		},
		"course": {
			"id": 1,
			"title": "Awesome Course!"
		}
	}
	
### Get all showings for a course

#### Request

	GET /courses/{course_id}/showings.json

#### Example

	GET /courses/1/showings.json

#### Response

	200 OK
	
	[
		{
			"id": 1,
			"start_time": null,
			"end_time": null,
			"scenario": {
				"id": 1,
				"name": "My Scenario",
				"description": "My Scenario Description",
				"archived": false,
				"root_node_id": 1
			},
			"course": {
				"id": 1,
				"title": "Awesome Course!"
			}
		},
		{
			"id": 2,
			"start_time": "0001-02-15T00:00:00.000Z",
			"end_time": "0004-05-16T00:00:00.000Z",
			"scenario": {
				"id": 2,
				"name": "Chemistry Magic",
				"description": "Learn how to analyze magic.",
				"archived": false,
				"root_node_id": 2
			},
			"course": {
				"id": 1,
				"title": "Awesome Course!"
			}
		}
	]
