class ImsController < ActionController::Base
  def index
    public_path = Rails.root.join("public", "ims", "index.html")
    if public_path.exist?
      render file: public_path, layout: false
    else
      render plain: <<~HTML, content_type: "text/html"
        <!DOCTYPE html>
        <html>
        <head>
          <title>Scanova IMS</title>
          <style>
            body { font-family: -apple-system, sans-serif; display: flex; align-items: center;
                   justify-content: center; min-height: 100vh; margin: 0; background: #f8fafc; }
            .card { background: white; border-radius: 12px; padding: 40px; max-width: 480px;
                    box-shadow: 0 4px 20px rgba(0,0,0,.08); text-align: center; }
            h1 { color: #0f766e; margin: 0 0 8px; }
            p { color: #64748b; margin: 8px 0; }
            .badge { display: inline-block; background: #0f766e; color: white; border-radius: 999px;
                     padding: 4px 14px; font-size: 13px; font-weight: 600; margin-top: 16px; }
            a { color: #0f766e; }
          </style>
        </head>
        <body>
          <div class="card">
            <h1>🔬 Scanova IMS</h1>
            <p>Rails API is running and ready.</p>
            <p>The React frontend has not been built yet. Run:</p>
            <pre style="background:#f1f5f9;padding:12px;border-radius:6px;font-size:13px;text-align:left">
        cd artifacts/pathology-app
        pnpm build --mode rails</pre>
            <p>Then place the build output in <code>public/ims/</code></p>
            <span class="badge">API Ready</span>
            <p style="margin-top:16px"><a href="/api/healthz">API Health Check</a></p>
          </div>
        </body>
        </html>
      HTML
    end
  end
end
