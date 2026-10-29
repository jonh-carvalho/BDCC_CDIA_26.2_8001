from django.db import models

class Pet(models.Model):    
    name = models.CharField(max_length=100)
    species = models.CharField(max_length=50)
    age = models.IntegerField()
    breed = models.CharField(max_length=100)
    owner = models.CharField(max_length=100)

    def __str__(self):
        return f"{self.name} ({self.species})"
