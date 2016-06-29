## Example Endpoint

### Get all posts

#### Request

	GET /posts.json

#### Response

	200 OK

	[
		{
			id:1,
			title: "Cool Post"
		},
		{
			id:2,
			title: "Even Cooler Posts"
		}
	]

### Get a post

#### Request

	GET /posts/{id}.json

#### Example

	GET /posts/1.json

#### Response

	200 OK

	{
		id: 1,
		title: "Cool Post"	
	}

### Create a post

#### Request

	POST /posts.json

#### Payload

	{
		title: "My Post"
	}

#### Response

	201 Created
	
	{
		id: 3,
		title: "My Post"
	}
	
	