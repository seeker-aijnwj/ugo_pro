from django.http import HttpResponse
from django.shortcuts import render    
from u_go.feedback.models import Band

# Create your views here.

def hello(request):
    """
    A simple view that returns a greeting.
    """
    bands = Band.objects.all()
    return render(request, 'listings/index.html', {'bands': bands})
