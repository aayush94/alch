## Nodes Endpoint

### Create a node

#### Request

	POST /scenarios/{scenario_id}/nodes.json

#### Example

	POST /scenarios/1/nodes.json

#### Response

	201 Created
	
	{
		"id": 2,
		"title": "",
		"body": "",
		"is_start": false,
		"is_goal": false,
		"is_failure": false,
		"requires_justification": false,
		"scenario": {
			"id": 1,
			"name": "My Scenario",
			"description": "My Scenario Description",
			"archived": false,
			"root_node_id": 1
		}
	}

### Get a node

#### Request

	GET /scenarios/{scenario_id}/nodes/{node_id}.json

#### Example

	GET /scenarios/1/nodes/2.json

#### Response

	200 OK
	
	{
		"id": 2,
		"title": "",
		"body": "",
		"is_start": false,
		"is_goal": false,
		"is_failure": false,
		"requires_justification": false,
		"scenario": {
			"id": 1,
			"name": "My Scenario",
			"description": "My Scenario Description",
			"archived": false,
			"root_node_id": 1
		}
	}
	
### Update a node

#### Request

	PUT /scenarios/{scenario_id}/nodes/{node_id}.json

#### Example
	PUT /scenarios/1/nodes/2.json

#### Payload

	{
		"title": "My Node Title",
		"body": "My Node Body",
		"is_goal" : true
	}

##### Fields
Note that all fields are optional.

* `title`: String title of the node.
* `body`: String body of the node.
* `is_goal`: Boolean denoting whether or node is a goal.
* `is_failure`: Boolean denoting whether or not node is a failure.
* `requires_justification`: Boolean denoting if node requires short answer response.

#### Response

	204 No Content
	
	
### Delete a node

#### Request

	DELETE /scenarios/{scenario_id}/nodes/{node_id}.json

#### Example

	DELETE /scenarios/1/nodes/2.json

#### Response

	204 No Content