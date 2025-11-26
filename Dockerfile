# Use small nginx image to serve static HTML
FROM nginx:alpine
# remove default index if any and copy our index.html
RUN rm -f /usr/share/nginx/html/*
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
