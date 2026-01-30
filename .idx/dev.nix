# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com
{ pkgs, ... }: {
  # تحديث القناة إلى أحدث إصدار مستقر (24.11) للحصول على دعم أفضل
  channel = "stable-24.11";

  packages = [
    pkgs.python311       # نسخة مستقرة وسريعة مع Flet
    pkgs.jdk17           # إصدار LTS الموصى به لتطبيقات الجافا والأندرويد
    pkgs.pipx            # لأدوات بايثون الإضافية
    pkgs.git             # أساسي لإدارة المشروع
  ];

  # إعداد متغيرات البيئة
  env = {
    VENV_DIR = ".venv";
    MAIN_FILE = "main.py";
  };

  idx = {
    # إضافات VS Code الضرورية لتطوير بايثون و Flet
    extensions = [
      "ms-python.python"
      "ms-python.debugpy"
      "ms-python.vscode-pylint"
    ];

    workspace = {
      # يتم التنفيذ عند إنشاء مساحة العمل لأول مرة فقط
      onCreate = {
        setup-venv = ''
          python -m venv $VENV_DIR
          source $VENV_DIR/bin/activate
          pip install --upgrade pip
          
          if [ ! -f requirements.txt ]; then
            echo "flet" > requirements.txt
          fi
          
          pip install -r requirements.txt
        '';
      };

      # يتم التنفيذ في كل مرة يتم فيها تشغيل مساحة العمل
      onStart = {
        install-dependencies = ''
          source $VENV_DIR/bin/activate
          pip install -r requirements.txt
        '';
        # فتح الملفات الأساسية تلقائياً عند البدء
        default.openFiles = [ "README.md" "requirements.txt" "$MAIN_FILE" ];
      };
    };

    # إعدادات المعاينة المباشرة (Web Preview)
    previews = {
      enable = true;
      previews = {
        web = {
          command = [
            "bash"
            "-c"
            ''
            source $VENV_DIR/bin/activate
            # تشغيل Flet مع تفعيل ميزة الـ Hot Reload على المنفذ المخصص من IDX
            flet run $MAIN_FILE --web --port $PORT
            ''
          ];
          manager = "web";
        };
      };
    };
  };
}
