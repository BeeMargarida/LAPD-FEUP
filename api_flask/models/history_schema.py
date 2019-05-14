from jsonschema import validate
from jsonschema.exceptions import ValidationError
from jsonschema.exceptions import SchemaError

history_schema = {
    "type": "object",
    "properties": {
        "type": {
            "type": "string"
        },
        "imagePath": {
            "type": "string"
        },
        "user_id": {
            "type": "string",
        }
    },
    "required": ["type", "user_id"],
    "additionalProperties": True
}


def validate_history(data):
    try:
        validate(data, history_schema)
    except ValidationError as e:
        return {'ok': False, 'message': e}
    except SchemaError as e:
        return {'ok': False, 'message': e}
    return {'ok': True, 'data': data}
