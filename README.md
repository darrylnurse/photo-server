Run local: ```gleam run```

Run docker (obviously once you have the docker engine): ```docker run --env=DATABASE_URL=<your_database_url> -p 2626:2626 photo-server```

Rebuild docker: ```docker build -t photo-server .```