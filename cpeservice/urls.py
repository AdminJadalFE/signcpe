from django.urls import path
from .views import GenerarCPEView

urlpatterns = [
    path('generarcpe', GenerarCPEView.as_view(), name='generarcpe'),
]