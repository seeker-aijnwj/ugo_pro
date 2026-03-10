from django.db import models
# from utilisateurs.models import Utilisateur

# Create your models here.

# It contains the data models for your listings.

"""
class Trajet(models.Model):
    conducteur = models.ForeignKey(Utilisateur, on_delete=models.CASCADE, related_name='trajets')
    lieu_depart = models.CharField(max_length=255)
    lat_depart = models.FloatField(null=True, blank=True)
    long_depart = models.FloatField(null=True, blank=True)
    lieu_arrivee = models.CharField(max_length=255)
    lat_arrivee = models.FloatField(null=True, blank=True)
    long_arrivee = models.FloatField(null=True, blank=True)
    date_depart = models.DateField()
    heure_depart = models.TimeField()
    places_disponibles = models.PositiveIntegerField()
    prix_par_place = models.DecimalField(max_digits=6, decimal_places=2)
    description = models.TextField(blank=True)
    est_actif = models.BooleanField(default=True)
    date_creation = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.lieu_depart} ➜ {self.lieu_arrivee} ({self.date_depart})"


class PointIntermediaire(models.Model):
    trajet = models.ForeignKey(Trajet, on_delete=models.CASCADE, related_name='points_intermediaires')
    lieu = models.CharField(max_length=255)
    lat = models.FloatField(null=True, blank=True)
    lon = models.FloatField(null=True, blank=True)
    description = models.TextField(blank=True)
    ordre = models.PositiveIntegerField()

    def __str__(self):
        return f"{self.lieu} - étape {self.ordre}"

"""