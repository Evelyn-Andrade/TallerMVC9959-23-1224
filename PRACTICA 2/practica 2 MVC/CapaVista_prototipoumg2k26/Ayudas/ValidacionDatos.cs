using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel;

namespace CapaVista_prototipoumg2k26.Ayudas
{
    public class ValidacionDatos
    {
        private ValidationContext contexto;
        private List<ValidationResult> resultados;
        private bool valido;
        private String Mensaje;
        public ValidacionDatos(object instancia)
        {
            contexto = new ValidationContext(instancia);
            resultados = new List<ValidationResult>();
            valido = Validator.TryValidateObject(instancia, contexto, resultados, true);
        }
        public bool Validar()
        {
            if (valido == false)
            {
                foreach (ValidationResult item in resultados)
                {
                    Mensaje += item.ErrorMessage + "\n";
                }
                System.Windows.Forms.MessageBox.Show(Mensaje);
            }
            return valido;

        }
    }
}
