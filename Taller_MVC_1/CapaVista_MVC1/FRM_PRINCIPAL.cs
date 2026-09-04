using CapaControlador_MVC1;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace CapaVista_MVC1
{
    public partial class FRM_PRINCIPAL : Form
    {
        string nombreTabla = "video";
        Controlador controlador = new Controlador();
        public FRM_PRINCIPAL()
        {
            InitializeComponent();
        }

        public void actualizarDataGridView()
        {
            DataTable dtVista = controlador.llenarDgv(nombreTabla);
            dgvConsultaTabla.DataSource = dtVista;
        }

        private void Principal_Load(object sender, EventArgs e)
        {

        }

        private void FRM_PRINCIPAL_Load(object sender, EventArgs e)
        {

        }

        private void btn_consulta_Click(object sender, EventArgs e)
        {
            actualizarDataGridView(); 
        }
    }
}
