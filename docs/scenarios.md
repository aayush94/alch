## Scenarios Endpoint

### Create a scenario

#### Request

	POST /scenarios.json

#### Payload

	{
		"title": "My Scenario",
		"description": "My Scenario Description",
	}

* `description` is optional.

#### Response

	201 Created
	
  ```javascript
	{
		"id": 1,
		"title": "My Scenario",
		"description": "My Scenario Description",
		"archived": false,
		"root_node_id": 1
	}
  ```

  401 Unauthorized
  `No Payload`

  422 Unprocessable Entity
  If Scenario name already in use or could not create root node

  ```javascript
  [{name: ["already in use"]}]
  ```

### Update a scenario

#### Request
	PUT /scenarios/{scenario_id}

#### Example
	PUT /scenarios/1

#### Payload

	{
		"name" : "Updated Name"
	}

#### Response

	204 No Content

### Copy a scenario

#### Request

	POST /scenarios/{scenario_id}/copy

#### Payload

	{
		"title": "Copied Scenario Name"
	}

* `title` is optional. If not provided a new scenario name will be generated based off the previous one.

#### Response

	201 Created
	
	{
		"id": 13,
		"name": "My Cool Scenario Copy 20fec91a032adea9",
		"description": "The Best Scenario Around",
		"archived": false,
		"root_node_id": 91
	}