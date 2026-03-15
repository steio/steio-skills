output "apex_A_address" {
  value = namecheap_record.a_root.address
}

output "www_CNAME_address" {
  value = namecheap_record.www.address
}

output "mx_address" {
  value = namecheap_record.mx.address
}

output "spf_address" {
  value = namecheap_record.spf.address
}

output "dmarc_address" {
  value = namecheap_record.dmarc.address
}

output "caa_address" {
  value = namecheap_record.caa.address
}
