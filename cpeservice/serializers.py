from rest_framework import serializers

class GenerarCPESerializer(serializers.Serializer):
    class Meta:
        id = serializers.IntegerField(read_only=True)

