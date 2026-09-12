using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Odbc;
using CapaModelo_prototipoumg2k26.Entidades;
using CapaModelo_prototipoumg2k26.Contratos;

namespace CapaModelo_prototipoumg2k26.Repositorios
{
    public class RepositorioVideo : RepositorioMaestro, IRepositorioVideo
    {
        private string selectAll;
        private string insert;
        private string update;
        private string delete;

        public RepositorioVideo()
        {
            selectAll = "SELECT * FROM video";
            insert = "INSERT INTO video VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            update = "UPDATE video SET titulo=?, genero=?, precio_renta=?, stock=?, " +
                        "estado=?, codigo=?, director=?, anio=?, clasificacion=?, " +
                        "duracion=?, idioma=? WHERE id_video=?";
            delete = "DELETE FROM video WHERE id_video=?";
        }

        public int Agregar(Video entidad)
        {
            var _parametros = new List<OdbcParameter>();
            _parametros.Add(new OdbcParameter("p_titulo", entidad.Titulo));
            _parametros.Add(new OdbcParameter("p_genero", entidad.Genero));
            _parametros.Add(new OdbcParameter("p_precio_renta", entidad.PrecioRenta));
            _parametros.Add(new OdbcParameter("p_stock", entidad.Stock));
            _parametros.Add(new OdbcParameter("p_estado", entidad.Estado));
            _parametros.Add(new OdbcParameter("p_codigo", entidad.Codigo));
            _parametros.Add(new OdbcParameter("p_director", entidad.Director));
            _parametros.Add(new OdbcParameter("p_anio", entidad.Anio));
            _parametros.Add(new OdbcParameter("p_clasificacion", entidad.Clasificacion));
            _parametros.Add(new OdbcParameter("p_duracion", entidad.Duracion));
            _parametros.Add(new OdbcParameter("p_idioma", entidad.Idioma));
            return EjecucionNonQuery(insert, _parametros, CommandType.Text);
        }

        public int Editar(Video entidad)
        {
            var _parametros = new List<OdbcParameter>();
            _parametros.Add(new OdbcParameter("p_titulo", entidad.Titulo));
            _parametros.Add(new OdbcParameter("p_genero", entidad.Genero));
            _parametros.Add(new OdbcParameter("p_precio_renta", entidad.PrecioRenta));
            _parametros.Add(new OdbcParameter("p_stock", entidad.Stock));
            _parametros.Add(new OdbcParameter("p_estado", entidad.Estado));
            _parametros.Add(new OdbcParameter("p_codigo", entidad.Codigo));
            _parametros.Add(new OdbcParameter("p_director", entidad.Director));
            _parametros.Add(new OdbcParameter("p_anio", entidad.Anio));
            _parametros.Add(new OdbcParameter("p_clasificacion", entidad.Clasificacion));
            _parametros.Add(new OdbcParameter("p_duracion", entidad.Duracion));
            _parametros.Add(new OdbcParameter("p_idioma", entidad.Idioma));
            _parametros.Add(new OdbcParameter("p_id_video", entidad.IdVideo));
            return EjecucionNonQuery(update, _parametros, CommandType.Text);
        }

        public int Remover(Video entidad)
        {
            var _parametros = new List<OdbcParameter>();
            _parametros.Add(new OdbcParameter("p_id_video", entidad.IdVideo));
            return EjecucionNonQuery(delete, _parametros, CommandType.Text);
        }

        public IEnumerable<Video> GetAll()
        {
            var lstVideo = new List<Video>();
            var tblTabla = EjecucionConsulta(selectAll, CommandType.Text);
            foreach (DataRow row in tblTabla.Rows)
            {
                var video = new Video();
                video.IdVideo = Convert.ToInt32(row[0]);
                video.Titulo = row[1].ToString();
                video.Genero = row[2].ToString();
                video.PrecioRenta = Convert.ToDecimal(row[3]);
                video.Stock = Convert.ToInt32(row[4]);
                video.Estado = row[5].ToString();
                video.Codigo = row[6].ToString();
                video.Director = row[7].ToString();
                video.Anio = Convert.ToInt32(row[8]);
                video.Clasificacion = row[9].ToString();
                video.Duracion = Convert.ToInt32(row[10]);
                video.Idioma = row[11].ToString();
                lstVideo.Add(video);
            }
            tblTabla.Clear();
            tblTabla = null;
            return lstVideo;
        }
    }
}