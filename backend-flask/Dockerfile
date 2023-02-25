# Stage 1: Build the Python application
FROM python:3.9-slim-buster AS build-python
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
COPY . .
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]

# Stage 2: Build the Nginx image
FROM nginx:1.21-alpine AS build-nginx
WORKDIR /usr/share/nginx/html
COPY --from=build-python . .
COPY --from=build-python . .
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Stage 3: Final image with just the built assets
FROM nginx:1.21-alpine
COPY --from=build-nginx /usr/share/nginx/html /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]