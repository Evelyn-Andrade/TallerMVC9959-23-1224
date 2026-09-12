using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CapaModelo_prototipoumg2k26.Contratos;
using CapaModelo_prototipoumg2k26.Entidades;
using CapaModelo_prototipoumg2k26.Repositorios;
using System.ComponentModel.DataAnnotations;

namespace CapaControlador_prototipoumg2k26
{
    public class ModeloVideo
    {
        private int _idVideo;
        private string _titulo;
        private string _genero;
        private decimal _precioRenta;
        private int _stock;
        private string _estadoVideo;
        private string _codigo;
        private string _director;
        private int _anio;
        private string _clasificacion;
        private int _duracion;
        private string _idioma;

        private IRepositorioVideo RepositorioVideo;

        public EstadoEntidad Estado { private get; set; }
        private List<ModeloVideo> ListaVideos;

        public int IdVideo { get => _idVideo; set => _idVideo = value; }

        [Required(ErrorMessage = "El campo titulo es requerido")]
        [StringLength(maximumLength: 100, MinimumLength = 1, ErrorMessage = "El titulo debe tener entre 1 y 100 caracteres")]
        public string Titulo { get => _titulo; set => _titulo = value; }

        [Required(ErrorMessage = "El campo genero es requerido")]
        public string Genero { get => _genero; set => _genero = value; }

        [Required(ErrorMessage = "El campo precio de renta es requerido")]
        public decimal PrecioRenta { get => _precioRenta; set => _precioRenta = value; }

        public int Stock { get => _stock; set => _stock = value; }

        public string EstadoVideo { get => _estadoVideo; set => _estadoVideo = value; }

        [Required(ErrorMessage = "El campo codigo es requerido")]
        public string Codigo { get => _codigo; set => _codigo = value; }

        [Required(ErrorMessage = "El campo director es requerido")]
        public string Director { get => _director; set => _director = value; }

        public int Anio { get => _anio; set => _anio = value; }

        public string Clasificacion { get => _clasificacion; set => _clasificacion = value; }

        public int Duracion { get => _duracion; set => _duracion = value; }

        public string Idioma { get => _idioma; set => _idioma = value; }

        public ModeloVideo()
        {
            RepositorioVideo = new RepositorioVideo();
        }

        public string GrabarCambios()
        {
            string mensaje = null;
            try
            {
                var modeloDatosVideo = new Video();
                modeloDatosVideo.IdVideo = _idVideo;
                modeloDatosVideo.Titulo = _titulo;
                modeloDatosVideo.Genero = _genero;
                modeloDatosVideo.PrecioRenta = _precioRenta;
                modeloDatosVideo.Stock = _stock;
                modeloDatosVideo.Estado = _estadoVideo;
                modeloDatosVideo.Codigo = _codigo;
                modeloDatosVideo.Director = _director;
                modeloDatosVideo.Anio = _anio;
                modeloDatosVideo.Clasificacion = _clasificacion;
                modeloDatosVideo.Duracion = _duracion;
                modeloDatosVideo.Idioma = _idioma;

                switch (Estado)
                {
                    case EstadoEntidad.Added:
                        RepositorioVideo.Agregar(modeloDatosVideo);
                        mensaje = "Grabacion exitosa";
                        break;
                    case EstadoEntidad.Modified:
                        RepositorioVideo.Editar(modeloDatosVideo);
                        mensaje = "Actualizacion exitosa";
                        break;
                    case EstadoEntidad.Deleted:
                        RepositorioVideo.Remover(modeloDatosVideo);
                        mensaje = "Eliminacion exitosa";
                        break;
                }
            }
            catch (Exception ex)
            {
                mensaje = ex.ToString();
            }
            return mensaje;
        }

        public List<ModeloVideo> GetAll()
        {
            var modeloDatosVideo = RepositorioVideo.GetAll();
            ListaVideos = new List<ModeloVideo>();
            foreach (Video item in modeloDatosVideo)
            {
                ListaVideos.Add(new ModeloVideo
                {
                    _idVideo = item.IdVideo,
                    _titulo = item.Titulo,
                    _genero = item.Genero,
                    _precioRenta = item.PrecioRenta,
                    _stock = item.Stock,
                    _estadoVideo = item.Estado,
                    _codigo = item.Codigo,
                    _director = item.Director,
                    _anio = item.Anio,
                    _clasificacion = item.Clasificacion,
                    _duracion = item.Duracion,
                    _idioma = item.Idioma
                });
            }
            return ListaVideos;
        }

        public IEnumerable<ModeloVideo> FindbyId(string filter)
        {
            return ListaVideos.FindAll(v => v.Titulo.Contains(filter) || v._codigo.Contains(filter));
        }
    }
}