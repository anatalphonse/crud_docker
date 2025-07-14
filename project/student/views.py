from django.shortcuts import render,redirect,get_object_or_404
from django.contrib.auth.decorators import login_required
from .models import student
from .forms import StudentForm
# Create your views here.

def add_student(request):
    if request.method == 'POST':
        form = StudentForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('student_list')
    else:
        form = StudentForm()
    return render(request, 'add_student.html',{'form':form})

@login_required
def student_list(request):
    students = student.objects.all()
    return render(request, 'student_list.html', {'students':students})

def edit_student(request,pk):
    students = get_object_or_404(student ,pk=pk)
    if request.method == "POST":
        form = StudentForm(request.POST, instance=students)
        if form.is_valid():
            form.save()
            return redirect('student_list')
    else:
        form = StudentForm(instance = students)
    return render(request, 'edit_student.html', {'form':form})

def delete_student(request,pk):
    students = get_object_or_404(student, pk = pk)
    if request.method == 'POST':
        students.delete()
        return redirect('student_list')
    return render(request ,'confirm_delete.html', {'students':students})
        




