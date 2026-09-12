-- Datos Insertados tabla video

INSERT INTO video (titulo, genero, precio_renta, stock, estado, codigo, director, anio, clasificacion, duracion, idioma) VALUES
('Avatar',                  'Ciencia Ficción', 25.00, 8,  'disponible', 'VID001', 'James Cameron',    2009, 'PG-13', 162, 'Español'),
('Titanic',                 'Romance',         20.00, 5,  'disponible', 'VID002', 'James Cameron',    1997, 'PG-13', 194, 'Español'),
('Jurassic Park',           'Aventura',        22.50, 6,  'disponible', 'VID003', 'Steven Spielberg', 1993, 'PG-13', 127, 'Español'),
('The Dark Knight',         'Acción',          30.00, 7,  'disponible', 'VID004', 'Christopher Nolan',2008, 'PG-13', 152, 'Español'),
('Toy Story',               'Animación',       18.00, 10, 'disponible', 'VID005', 'John Lasseter',    1995, 'G',     81,  'Español'),
('Coco',                    'Animación',       20.00, 9,  'disponible', 'VID006', 'Lee Unkrich',      2017, 'PG',    105, 'Español'),
('Avengers: Endgame',       'Acción',          35.00, 4,  'disponible', 'VID007', 'Anthony Russo',    2019, 'PG-13', 181, 'Español'),
('Spider-Man: No Way Home', 'Acción',          30.00, 6,  'disponible', 'VID008', 'Jon Watts',        2021, 'PG-13', 148, 'Español'),
('Frozen',                  'Animación',       18.50, 8,  'disponible', 'VID009', 'Chris Buck',       2013, 'PG',    102, 'Español'),
('The Lion King',           'Animación',       22.00, 5,  'disponible', 'VID010', 'Roger Allers',     1994, 'G',     88,  'Español');


select * from video