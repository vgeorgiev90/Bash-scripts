package main

import (
	"k8s/functions"
	//"fmt"
)

func main() {
	token := "eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJ2aWt0b3ItdG9rZW4tbnF4a2oiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoidmlrdG9yIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiYWJjYTllNjEtMGYzZS0xMWU5LTk5OWItMDIzODdhY2U0NjE1Iiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50Omt1YmUtc3lzdGVtOnZpa3RvciJ9.GEp_znrrx4BccG658gkYglLyeCax-MlP8982c0Te6i9iDWJ2Vta928KFUQVwiMZFOEghBvPYlxX9MK-PAF_6Mt4_br4LMOLZ4--0E_UlVjlyhbJUyKBS_R45t_YIIfJAuIHl78pJodLFWgDsUVrtlV1k0uVAGhYTg2tW158HAwBanwLHIffKZdoOtNlyPbbz00nvcaIH9_NfDsVMFcrOJQZo2thwnWf7MhGjPnRbTPVldJUqp74u_24R-02gulolxC84LpqK2SwWphw1sh70TxmvHE1K-5G6YMN3L8Z05PhqVjvestsMIzNo73vhAPi_Cz0GJgoxVi5VJiOoCrd46w"

	functions.Get("10.0.11.155:6443", token)

}
