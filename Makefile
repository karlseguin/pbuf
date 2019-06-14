F=
SCHEMA_DIR=test/schemas/
GOOGLE_PROTO_ROOT=/usr/local/include

.PHONY: bench
bench:
	MIX_ENV=test mix run test/benchmark.exs

# generate files necessary using a protoc generator built from this source
.PHONY: gen
gen:
	mix escript.build

# 	bootstrap the descriptor model
# 	rm -fr lib/protoc/google/
# 	protoc -I=${GOOGLE_PROTO_ROOT} -I=. --fast-elixir_out=./lib/protoc/ --plugin=protoc-gen-fast-elixir `find ${GOOGLE_PROTO_ROOT}/google/protobuf -name "*.proto" -not -path "*empty.proto"`

	rm -f ${SCHEMA_DIR}generated/*
	cd ${SCHEMA_DIR}proto/ && protoc -I=${GOOGLE_PROTO_ROOT} -I=. --elixir_out=. *.proto
	mv ${SCHEMA_DIR}proto/user.pb.ex ${SCHEMA_DIR}generated/sanity.user.pb.ex
	mv ${SCHEMA_DIR}proto/everything.pb.ex ${SCHEMA_DIR}generated/sanity.everything.pb.ex
	find ${SCHEMA_DIR}generated -name '*.pb.ex' -print0 | xargs -0 sed -i.bak -e 's/Pbuf.Tests./Sanity.Pbuf.Tests./g'
	find ${SCHEMA_DIR}generated -name '*.bak' -delete

	mv protoc-gen-fast-elixir ${SCHEMA_DIR}proto/
	cd ${SCHEMA_DIR}proto/ && protoc -I=${GOOGLE_PROTO_ROOT} -I=. --fast-elixir_out=. --plugin=protoc-gen-fast-elixir *.proto
	mv ${SCHEMA_DIR}proto/*.pb.ex ${SCHEMA_DIR}generated/
	rm -fr google

# 	-rm test/schemas/xxa/protoc-gen-fast-elixir
# 	cp protoc-gen-fast-elixir test/schemas/xxa/
# 	cd test/schemas/xxa/ && protoc -I=. --fast-elixir_out=. --plugin=protoc-gen-fast-elixir `find . -name "*.proto"`

.PHONY: t
t:
	mix test ${F}

.PHONY: p
p:
	rm -fr ./test/schemas/generated/*
	protoc --proto_path=./test/schemas/ \
		--fast-elixir_out=./test/schemas/generated/ \
		`find ./test/schemas -name "*.proto"`

