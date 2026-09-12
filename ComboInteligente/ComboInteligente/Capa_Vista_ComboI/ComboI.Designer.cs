namespace Capa_Vista_Combol
{
    partial class Combol
    {
        /// <summary> 
        /// Variable del diseñador necesaria.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// Limpiar los recursos que se estén usando.
        /// </summary>
        /// <param name="disposing">true si los recursos administrados se deben desechar; false en caso contrario.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Código generado por el Diseñador de componentes

        /// <summary> 
        /// Método necesario para admitir el Diseñador. No se puede modificar
        /// el contenido de este método con el editor de código.
        /// </summary>
        private void InitializeComponent()
        {
            this.cboPrueba = new System.Windows.Forms.ComboBox();
            this.SuspendLayout();
            // 
            // cboPrueba
            // 
            this.cboPrueba.Dock = System.Windows.Forms.DockStyle.Top;
            this.cboPrueba.FormattingEnabled = true;
            this.cboPrueba.Location = new System.Drawing.Point(0, 0);
            this.cboPrueba.Name = "cboPrueba";
            this.cboPrueba.Size = new System.Drawing.Size(690, 21);
            this.cboPrueba.TabIndex = 0;
            // 
            // Combol
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.cboPrueba);
            this.Name = "Combol";
            this.Size = new System.Drawing.Size(690, 27);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.ComboBox cboPrueba;
    }
}
