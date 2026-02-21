# Use the official OJS image
FROM pkp/ojs:3_3_0-14

# Set environment variables for the OJS installation
ENV OJS_DB_TYPE=postgres
ENV OJS_DB_HOST=localhost
ENV OJS_DB_USER=ojs
ENV OJS_DB_PASSWORD=ojs
ENV OJS_DB_NAME=ojs

# Expose the port OJS runs on
EXPOSE 80
