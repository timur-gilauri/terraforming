provider "aws" {
	profile = "default"
	region = "us-east-1"
}

resource "aws_dynamodb_table" "teams-dynamodb-table" {
	name			= "Teams"
	read_capacity	= 20
	write_capacity	= 20
	hash_key		= "TeamTitle"
	range_key		= "PlayerName"

	attribute {
		name = "TeamTitle"
		type = "S" 
	}

	attribute {
		name = "PlayerName"
		type = "S" 
	}
}

locals {
	items_vars = {
		table_name		= "${aws_dynamodb_table.teams-dynamodb-table.name}"
		hash_key		= "${aws_dynamodb_table.teams-dynamodb-table.hash_key}"
	}
	players_path	= "${path.module}/players.json"
	players 		= jsondecode(file(local.players_path))
}

resource "aws_dynamodb_table_item" "the-players" {
	count = length(local.players)

	table_name = local.items_vars.table_name
	hash_key = local.items_vars.hash_key

	item = jsonencode(local.players[count.index])
}