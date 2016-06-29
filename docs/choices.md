## Choices Endpoint

### Create a choice

#### Request

	POST /scenarios/{scenario_id}/nodes/{node_id}/choices.json

#### Payload

	{
		"text": "Eat A Carrot",
		"to_node_id": 2
	}

* `text` is optional.
* `to_node_id` is optional. The node that the choice connects to.

#### Response

	201 Created

	{
		"id": 12,
		"text": "Eat A Carrot",
		"node_id": 1,
		"to_node_id": 2
	}


### Get a choice

#### Request

	GET /scenarios/{scenario_id}/nodes/{node_id}/choices/{choice_id}.json

#### Response

	200 OK

	{
		"id": 12,
		"text": "Eat A Carrot",
		"node_id": 1,
		"to_node_id": 2
	}

### Update a choice

#### Request

	PUT /scenarios/{scenario_id}/nodes/{node_id}/choices/{choice_id}.json

#### Payload

	{
		"text": "Updated text"
		"to_node_id": 3
	}

* `text` is optional.
* `to_node_id` is optional.

#### Response

	204 No Content

### Delete a choice

#### Request

	DELETE /scenarios/{scenario_id}/nodes/{node_id}/choices/{choice_id}.json

#### Response

	204 No Content