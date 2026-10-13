from typing import Any, Optional, Dict
from fastapi.encoders import jsonable_encoder

def format_api_response(
    success: bool,
    message: str,
    data: Optional[Any] = None,
    status_code: int = 200,
    errors: Optional[Any] = None
) -> Dict[str, Any]:
    """
    Standardized API response formatter for FastAPI endpoints.

    :param success: Boolean flag indicating if the operation succeeded.
    :param message: Descriptive response message.
    :param data: Output payload (Pydantic model, SQLAlchemy model, list, dict, etc.).
    :param status_code: HTTP status code corresponding to the response.
    :param errors: Error details or validation errors, if applicable.
    :return: A dictionary ready to be returned by FastAPI or wrapped in JSONResponse.
    """
    response = {
        "success": success,
        "status_code": status_code,
        "message": message,
        "data": jsonable_encoder(data) if data is not None else None,
    }

    if errors is not None:
        response["errors"] = jsonable_encoder(errors)

    return response