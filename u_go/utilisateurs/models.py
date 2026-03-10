from django.db import models
from django.contrib.auth.models import AbstractUser

# Create your models here.

"""
class Utilisateur(AbstractUser):
    ROLE_CHOICES = (
        ('conducteur', 'Conducteur'),
        ('passager', 'Passager'),
        ('admin', 'Administrateur'),
    )
    role = models.CharField(max_length=20, choices=ROLE_CHOICES)
    telephone = models.CharField(max_length=20, blank=True, null=True)
    photo_profil = models.ImageField(upload_to='profils/', blank=True, null=True)
    bio = models.TextField(blank=True)
    is_verified = models.BooleanField(default=False)  # pour vérif email/téléphone/pièce
    way_verified = models.CharField(max_length=100, default='Par Email')  # pour le moyen

    def __str__(self):
        return f"{self.username} ➜ {self.first_name} {self.last_name} ({self.email} et {self.telephone})"
"""