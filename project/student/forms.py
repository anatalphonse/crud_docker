# forms.py
from django import forms
from .models import student

class StudentForm(forms.ModelForm):
    class Meta:
        model = student
        fields = ['name','age', 'email']  # Only 'name' and 'email' fields in form
