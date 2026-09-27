FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install prometheus client
RUN pip install prometheus-client

# Copy the python script
COPY delivery_metrics.py /app/

# Expose the metrics port
EXPOSE 8000

# Run the application
CMD ["python", "delivery_metrics.py"]
