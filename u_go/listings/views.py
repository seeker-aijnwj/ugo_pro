from django.http import HttpResponse
from django.shortcuts import render

# Create your views here.

def index(request):
    """
    Render the index page.
    return render(request, 'listings/index.html')
    """
    return HttpResponse("Welcome to the U-Go Listings App!")

def about(request):
    """
    Render the about page.
    return render(request, 'listings/about.html')
    """
    return HttpResponse("About U-Go Listings App")

def contact(request):
    """
    Render the contact page.
    return render(request, 'listings/contact.html')
    """
    return HttpResponse("Contact U-Go Listings App")
