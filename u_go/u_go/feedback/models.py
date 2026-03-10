from django.db import models

# Create your models here.
class Band(models.Model):
    name = models.CharField(max_length=100)
    # genre = models.CharField(max_length=50)
    # formed_year = models.IntegerField()

    def __str__(self):
        return self.name
    
class Listing(models.Model):
    title = models.CharField(max_length=100)
    # band = models.ForeignKey(Band, on_delete=models.CASCADE)
    # comment = models.TextField()
    # rating = models.IntegerField()

    def __str__(self):
        return self.title
        # return f"{self.band.name} - {self.rating}/5"