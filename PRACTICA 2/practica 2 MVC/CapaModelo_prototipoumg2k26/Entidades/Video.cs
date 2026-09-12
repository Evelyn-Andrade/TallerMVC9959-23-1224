using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo_prototipoumg2k26.Entidades
{
    public class Video
    {
        public int IdVideo { get; set; }
        public string Titulo { get; set; }
        public string Genero { get; set; }
        public decimal PrecioRenta { get; set; }
        public int Stock { get; set; }
        public string Estado { get; set; }
        public string Codigo { get; set; }
        public string Director { get; set; }
        public int Anio { get; set; }
        public string Clasificacion { get; set; }
        public int Duracion { get; set; }
        public string Idioma { get; set; }
    }
}