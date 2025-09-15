[1mdiff --git a/start.sh b/start.sh[m
[1mindex 7236044..e77818e 100644[m
[1m--- a/start.sh[m
[1m+++ b/start.sh[m
[36m@@ -25,13 +25,23 @@[m [mecho "  ./df - Run Dwarf Fortress"[m
 echo "  ./dfhack - Run Dwarf Fortress with DFHack"[m
 echo "  ./dfhack-run - Run DFHack scripts"[m
 [m
[32m+[m[32m# Start API server in background[m
[32m+[m[32mecho "Starting Dwarf Fortress API server on port 8080..."[m
[32m+[m[32mcd /opt/dwarf-fortress[m
[32m+[m[32mpython3 df_api_server.py &[m
[32m+[m[32mAPI_PID=$![m
[32m+[m[32mecho "API server started (PID: $API_PID)"[m
[32m+[m
[32m+[m[32m# Return to DF directory[m
[32m+[m[32mcd /opt/dwarf-fortress/df[m
[32m+[m
 echo ""[m
 echo "Starting DFHack-enabled Dwarf Fortress..."[m
 [m
 # Function to cleanup on exit[m
 cleanup() {[m
     echo "Cleaning up..."[m
[31m-    kill $XVFB_PID $VNC_PID $WM_PID 2>/dev/null || true[m
[32m+[m[32m    kill $XVFB_PID $VNC_PID $WM_PID $API_PID 2>/dev/null || true[m
     exit[m
 }[m
 [m
