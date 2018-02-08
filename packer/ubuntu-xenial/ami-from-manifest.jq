.last_run_uuid as $id
  | .builds
  | map(select(.packer_run_uuid == $id))
  | .[0] # TODO: recover if no match found
  | .artifact_id
