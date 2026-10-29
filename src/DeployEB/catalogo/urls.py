from django.contrib import admin
from django.http import JsonResponse
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

def healthcheck(_request):
    return JsonResponse({'status': 'ok'})

urlpatterns = [
    path('', healthcheck),  # Health check do EB retorna 200
    path('admin/', admin.site.urls),
    path('api/', include('produtos.urls')),
]

# Configuração para servir arquivos de mídia em desenvolvimento
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)