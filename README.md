# Live Site:

snackpackmailer.com

# Problem:

Email campaigns. Snackpack focuses on creating email templates, tracking the success of deliveries, and the success of campaigns.

In particular it confronts the infrastructural problem of fault tolerance in the face of unresponsive or badly behaving remote providers (email services). 

Logical next steps would include tracking click through rates and open rates of campaigns.

# Solution:

The email jobs queue shares a set of Circuit Breaker objects in its thread pool, so that workers can share knowledge of the state of a remote API.

The circuit breakers shut off remote calls to any email service that has failed in 30% of the past 100 calls, opting for known-good services.

Deliverers use an adapter pattern to allow for easy configuration of new email services. 

The system is presented through a JSON API & interactive documentation, as the primary focus in this project was the backend services.

The system uses Rails for its fast iteration speed & Ruby because its code blocks make the dynamic programming challenges of this problem easy to solve.

In the future, the application should be refactored to perform load-balancing among email service providers; it was originally conceived that users of the Snackpack API would select their preferred email provider, which would provide some ad hoc load balancing, but I ultimately decided users should not be able to set their provider.

#### Reference material:

* http://martinfowler.com/bliki/CircuitBreaker.html
* http://techblog.netflix.com/2012/02/fault-tolerance-in-high-volume.html

# Snackpack API

* [Auth Token](#auth-token)
* [Templates](#templates)
  * [List](#list-templates)
  * [Show](#show-template)
  * [Create](#create-template)
  * [Update](#update-template)
  * [Delete](#delete-template)
* [Recipients](#recipients)
  * [List](#list-recipients)
  * [Show](#show-recipient)
  * [Create](#create-recipient)
  * [Update](#update-recipient)
  * [Delete](#delete-recipient)
* [Deliveries](#deliveries)
  * [List](#list-deliveries)
  * [Show](#show-delivery)
  * [Create](#create-delivery)
  * [Delete](#delete-delivery)
* [Campaigns](#campaigns)
  * [List](#list-campaigns)
  * [Show](#show-campaign)
  * [Create](#create-campaign)
  * [Update](#update-campaign)
  * [Delete](#delete-campaign)

## Auth Token

When you need to make requests to the API from another location, you'll need your auth_token. You can use your auth_token in the Authorization Header ("auth_token YOUR_TOKEN") or as the `auth_token` query parameter.

```ruby
GET api/v1/auth_token
```

## Templates

Templates are used to create emails. They can contain a subject, html, and text field to be used in the template, and can use `ERB` syntax to pass values into the template. 

Templates are allotted the special variable `recipient`, which can be used to pass through the recipient's information on all deliveries. The `recipient` object has the properties `email`, `first_name`, `last_name`, and `full_name` that can be accessed with standard Ruby syntax.

For example, the HTML portion of a template may look like:

```ruby
<h1>Welcome <%%= recipient.first_name %>!</h1>
<p>You signed up with <%%= recipient.email %>. Thanks for being awesome.</p>

<p>Sincerely, the management</p>
```

### List Templates
```ruby
GET api/v1/templates
```

#### Permissions:

Users may list their own templates.

#### Example Request:

```ruby
GET api/v1/templates

[
	{
		id: 1,
		name: 'My Great Email Template',
		subject: 'Thanks for signing up!',
		html: '<p><%%= recipient.full_name %>, you rock!</p>'
		text: '<%%= recipient.full_name %>, you rock!'
	}
]
```

### Show Template
```ruby
GET api/v1/templates/:id
```

#### Permissions:

Users may show their own templates.

#### Example Request:

```ruby
GET api/v1/templates/1

{
	id: 1,
	name: "My Great Email Template",
	subject: "Thanks for signing up!",
	html: "<p><%%= recipient.full_name %>, you rock!</p>"
	text: "<%%= recipient.full_name %>, you rock!"
}
```

### Create Template
```ruby
POST api/v1/templates
```

#### Permissions:

Users may create their own templates.

#### Parameters:

| parameter | description | details | 
| :-------- | :---------- | :------ |
| name      | required string | The name of the template. Must be unique to the template creator | 
| subject      | optional string, default "No subject" | The subject of the email | 
| html      | optional ERB HTML string; required if text is absent | The HTML portion of the email |
| text      | optional ERB plaintext string; required if html is absent | The text portion of the email |
| campaign_id | optional integer | The primary key of the campaign |


#### Example Request:

```ruby
POST api/v1/templates

{
	name: "My Great Email Template",
	subject: "Thanks for signing up!",
	html: "<p><%%= recipient.full_name %>, you rock!</p>"
	text: "<%%= recipient.full_name %>, you rock!",
	campaign_id: 1
}
```

#### Example Response: 

```ruby
201 Created
Location: https://snackpackmailer.com/api/v1/templates/1

{
	id: 1,
	name: "My Great Email Template",
	subject: "Thanks for signing up!",
	html: "<p><%%= recipient.full_name %>, you rock!</p>"
	text: "<%%= recipient.full_name %>, you rock!",
	campaign: {
		id: 1,
		name: "My Great Email Campaign",
		queue: "medium"
	}
}
```

### Update Template
```ruby
PUT api/v1/templates/:id
```

#### Permissions:

Users may update their own templates.

#### Parameters:

| parameter | description | details | 
| :-------- | :---------- | :------ |
| name      | optional string | The name of the template. Must be unique to the template creator | 
| subject      | optional string | The subject of the email | 
| html      | optional ERB HTML string | The HTML portion of the email |
| text      | optional ERB plaintext string | The text portion of the email | 
| campaign_id | optional integer | The primary key of the campaign |


#### Example Request:

```ruby
PUT api/v1/templates/1

{
	subject: "Welcome to our service!"
}
```

#### Example Response: 

```ruby
200 OK

{
	id: 1,
	name: "My Great Email Template",
	subject: "Welcome to our service!",
	html: "<p><%%= recipient.full_name %>, you rock!</p>"
	text: "<%%= recipient.full_name %>, you rock!"
}
```

### Delete Template

```ruby
DELETE api/v1/templates/:id
```

#### Permissions:

Users may delete their own templates.

#### Example Request:

```ruby
DELETE api/v1/templates/1
```

#### Example Response: 

```ruby
204 No Content
```

## Recipients

Recipients are the users you send your emails to. Whenever you send an email, that user will be added to your recipients list.

### List Recipients
```ruby
GET api/v1/recipients
```

#### Permissions:

Users may list their own recipients.

#### Example Request:

```ruby
GET api/v1/recipients

[
	{
		id: 1,
		first_name: 'Aubrey',
		last_name: 'Graham',
		email: 'drizzy@drake.com',
		status: "ok"
	},
	{
		id: 2,
		first_name: 'Lil',
		last_name: 'Wayne',
		email: 'youngmoney@ymc.mb',
		status: "address_not_exist"
	}
]
```

### Show Recipient
```ruby
GET api/v1/recipients/:id
```

#### Permissions:

Users may show their own recipients.

#### Example Request:

```ruby
GET api/v1/recipients/1

{
		id: 1,
		first_name: 'Aubrey',
		last_name: 'Graham',
		email: 'drizzy@drake.com,
		status: "ok"
}
```

### Create Recipient
```ruby
POST api/v1/recipients
```

#### Permissions:

Users may create their own recipients.

#### Parameters:

| parameter | description | details | 
| :-------- | :---------- | :------ |
| first_name | required string | The recipient's first name | 
| last_name | required string  | The recipient's last name | 
| email     | required string  | The recipient's email address; must be unique within the scope of a given sender, but two senders can create different recipients with the same email address (and different names) |

#### Example Request:

```ruby
POST api/v1/recipients

{
	first_name: 'Aubrey',
	last_name: 'Graham',
	email: 'drizzy@drake.com,
}
```

#### Example Response: 

```ruby
201 Created
Location: https://snackpackmailer.com/api/v1/recipients/1

{
	id: 1,
	first_name: 'Aubrey',
	last_name: 'Graham',
	email: 'drizzy@drake.com,
	status: "ok"
}
```

### Update Recipient
```ruby
PUT api/v1/recipients/:id
```

#### Permissions:

Users may update their own recipients.

#### Parameters:

| parameter | description | details | 
| :-------- | :---------- | :------ |
| first_name | optional string | The recipient's first name | 
| last_name | optional string | The recipient's last name | 
| email     | optional string | The recipient's email |

#### Example Request:

```ruby
PUT api/v1/recipients/1

{
	email: "six_god@drake.com"
}
```

#### Example Response: 

```ruby
200 OK

{
	id: 1,
	first_name: 'Aubrey',
	last_name: 'Graham',
	email: 'six_god@drake.com,
	status: "ok"
}
```

### Delete Recipient

```ruby
DELETE api/v1/recipients/:id
```

#### Permissions:

Users may delete their own recipients.

#### Example Request:

```ruby
DELETE api/v1/recipients/1
```

#### Example Response: 

```ruby
204 No Content
```

## Deliveries

Deliveries are the attempts to deliver emails to the recipients in a campaign. Upon creation, a delivery will be queued up to be delivered using the queue priority of its associated campaign. Delivery status codes are the most important part:

### Delivery Statuses:

* `created`: Delivery created, but not yet sent
* `sent`: Delivery sent successfully
* `failed`:  The email template contained an error, such as `<p><%%= raise "FAIL" %></p>`
* `hard_bounced`: The recipient's email address does not exist. Results from an SMTP status code of `512` or `550`.
* `not_sent`: The email did not hard bounce, but could not be delivered for another reason that may be fixed in the future (e.g. the user's email box was full). Although Snackpack contains failover support for multiple email providers, in the unlikely event that all providers are unresponsive, Snackpack will also use this error to indicate that the delivery failed, but may be successful in the future.

### List Deliveries

```ruby
GET api/v1/deliveries
```

#### Permissions:

Users may list their own deliveries.

#### Parameters:

| parameter | description | details | 
| :-------- | :---------- | :------ |
| status    | optional string | Lists deliveries of the given status (created, sent, not_sent, failed, hard_bounced)|
| campaign_id | optional integer | List all deliveries associated with a campaign | 
| template_id      | optional integer | List all deliveries associated with a template | 

#### Example Request:

```ruby
GET api/v1/deliveries

[
	{
		id: 1,
		status: "sent",
		recipient: {
			id: 1,
			first_name: "Aubrey",
			last_name: "Graham",
			email: "drizzy@drake.net"
		},
		template_id: 1,
		campaign_id: 1
	}
]
```

### Show Delivery

```ruby
GET api/v1/deliveries/:id
```

#### Permissions:

Users may show their own deliveries.

#### Example Request:

```ruby
GET api/v1/deliveries/1

{
	id: 1,
	status: "sent",
	recipient: {
		id: 1,
		first_name: "Aubrey",
		last_name: "Graham",
		email: "drizzy@drake.net"
	},
	template_id: 1,
	campaign_id: 1
}
```

### Create Delivery

```ruby
POST api/v1/deliveries
```

#### Permissions:

Users may create their own deliveries.

#### Parameters:

| parameter | description | details | 
| :-------- | :---------- | :------ |
| recipient_id      | optional string; required if recipient is absent | The id of the recipient, if a recipient has already been created | 
| recipient      | optional hash | A hash containing the first_name, last_name, and email of the recipient | 
| data | optional hash | The object to use to fill in the template |
| template_id      | required integer | The id of the template to use for the delivery |
| campaign_id      | required integer | The id of the campaign to use for the delivery |
| send_at | optional datetime | The datetime to send the email at |


#### Example Request:

```ruby
POST api/v1/deliveries

{
	recipient_id: 1,
	template_id: 1,
	campaign_id: 1,
	data: {
		company_name: "My Great Company"
	},
	send_at: "Wed Feb 25 2015 22:50:54"
}
```

#### Example Response: 

```ruby
201 Created
Location: https://snackpackmailer.com/api/v1/deliveries/1

{
	id: 1,
	status: "created",
	recipient: {
		id: 1,
		first_name: "Aubrey",
		last_name: "Graham",
		email: "drizzy@drake.net"
	},
	template_id: 1,
	campaign_id: 1
}
```

### Delete Delivery

```ruby
DELETE api/v1/deliveries/:id
```

#### Permissions:

Users may delete their own deliveries.

#### Example Request:

```ruby
DELETE api/v1/deliveries/1
```

#### Example Response: 

```ruby
204 No Content
```

## Campaigns

Campaigns are coordinated sets of emails with a given email template to a list of recipients. Campaigns monitor the overall deliveries to the campaign's recipients.

### List Campaigns

```ruby
GET api/v1/campaigns
```

#### Permissions:

Users may list their own campaigns.

#### Example Request:

```ruby
GET api/v1/campaigns

[
	{
		id: 1,
		name: "My Great Email Campaign",
		queue: "medium",
		sent_count: 5
		send_rate: 100
	}
]
```

### Show Campaign

```ruby
GET api/v1/campaigns/:id
```

#### Permissions:

Users may show their own campaigns.

#### Example Request:

```ruby
GET api/v1/campaigns/1

{
	id: 1,
	name: "My Great Email Campaign",
	queue: "medium",
	sent_count: 5
	send_rate: 100
}
```

### Create Campaign

```ruby
POST api/v1/campaigns
```

#### Permissions:

Users may create their own campaigns.

#### Parameters:

| parameter | description | details | 
| :-------- | :---------- | :------ |
| name      | required string | The name of the campaign. Must be unique to the campaign creator | 
| queue     | optional string, default "medium" | the priority of the campaign's deliveries (options are "low", "medium", and "high") |


#### Example Request:

```ruby
POST api/v1/campaigns

{
	name: "My Great Email Campaign",
	queue: "high"
}
```

#### Example Response: 

```ruby
201 Created
Location: https://snackpackmailer.com/api/v1/campaigns/1

{
	id: 1,
	name: "My Great Email Campaign",
	queue: "high",
	sent_count: 0
	send_rate: 0
}
```

### Update Campaign

```ruby
PUT api/v1/campaigns/:id
```

#### Permissions:

Users may update their own campaigns.

#### Parameters:

| parameter | description | details | 
| :-------- | :---------- | :------ |
| name      | optional string | The name of the campaign. Must be unique to the campaign creator | 
| queue     | optional string | the priority of the campaign's deliveries (options are "low", "medium", and "high") |


#### Example Request:

```ruby
PUT api/v1/campaigns/1

{
	queue: "low"
}
```

#### Example Response: 

```ruby
200 OK

{
	id: 1,
	name: "My Great Email Campaign",
	slug: "my-great-email-campaign",
	queue: "low",
	sent_count: 0
	send_rate: 0
}
```


### Delete Campaign

```ruby
DELETE api/v1/campaigns/:id
```

#### Permissions:

Users may delete their own campaigns.

#### Example Request:

```ruby
DELETE api/v1/campaigns/1
```

#### Example Response: 

```ruby
204 No Content
```
