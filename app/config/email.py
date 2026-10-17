from pydantic_settings import BaseSettings
from fastapi_mail import ConnectionConfig

class EmailSettings(BaseSettings):
    MAIL_USERNAME: str = "handy.customersupport@gmail.com" # Change own email
    MAIL_PASSWORD: str = "vrohrldhrbbhhons"  # Use App Passwords for Gmail
    MAIL_FROM: str = "handy.customersupport@gmail.com" # Change own email
    MAIL_PORT: int = 587
    MAIL_SERVER: str = "smtp.gmail.com"
    MAIL_STARTTLS: bool = True
    MAIL_SSL_TLS: bool = False
    MAIL_FROM_NAME: str = "Handy Reset Password"

email_settings = EmailSettings()

mail_config = ConnectionConfig(
    MAIL_USERNAME=email_settings.MAIL_USERNAME,
    MAIL_PASSWORD=email_settings.MAIL_PASSWORD,
    MAIL_FROM=email_settings.MAIL_FROM,
    MAIL_PORT=email_settings.MAIL_PORT,
    MAIL_SERVER=email_settings.MAIL_SERVER,
    MAIL_STARTTLS=email_settings.MAIL_STARTTLS,
    MAIL_SSL_TLS=email_settings.MAIL_SSL_TLS,
    MAIL_FROM_NAME=email_settings.MAIL_FROM_NAME,
    USE_CREDENTIALS=True,
    VALIDATE_CERTS=True,
)