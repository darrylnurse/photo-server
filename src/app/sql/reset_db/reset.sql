DROP TABLE IF EXISTS
    photos;

CREATE TABLE IF NOT EXISTS
    photos (
        id SERIAL PRIMARY KEY,
        date_added TEXT NOT NULL,
        url TEXT NOT NULL,
        slug TEXT UNIQUE NOT NULL,
        title TEXT NOT NULL,
        date_taKen TEXT,
        location TEXT,
        camera TEXT,
        focal_length TEXT,
        aperture TEXT,
        shutter_speed TEXT,
        iso INTEGER
    );

/*
    this sql is run using pgAdmin to reset the railway db
    no need to convert it to gleam using squirrel
*/