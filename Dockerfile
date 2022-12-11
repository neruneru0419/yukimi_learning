FROM public.ecr.aws/lambda/ruby:2.7

RUN yum groupinstall -y "Development Tools" \
    && yum install -y which openssl

RUN yum install -y git make gcc bzip2 openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel tar gzip && \
  git clone https://github.com/rbenv/ruby-build.git && \
  PREFIX=/usr/local ./ruby-build/install.sh

RUN  curl -L "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE" -o mecab-0.996.tar.gz \
    && tar xzf mecab-0.996.tar.gz \
    && cd mecab-0.996 \
    && ./configure --build=arm-linux --with-charset=utf8\
    && make \
    && make check \
    && make install \
    && cd .. \
    && rm -rf mecab-0.996*

RUN curl -L "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM" -o mecab-ipadic-2.7.0-20070801.tar.gz \
    && tar -zxvf mecab-ipadic-2.7.0-20070801.tar.gz \
    && cd mecab-ipadic-2.7.0-20070801 \
    && ./configure\
    && make \
    && make install \
    && cd .. \
    && rm -rf mecab-ipadic-2.7.0-20070801

# Copy function code
COPY . ${LAMBDA_TASK_ROOT}

# Install dependencies under LAMBDA_TASK_ROOT
ENV GEM_HOME=${LAMBDA_TASK_ROOT}

ENV api_key=ibaPlgZb5jZUXxaAmHHY7FuIV
ENV api_key_secret=MVK8xrtCR86AwJ265MMS09cqO3GbImbAWZC89u5T6WzrAEBi5e
ENV access_token=1400835865601925126-NrpgqXKRyiU3Nz7jTWlcft7e4CEgra
ENV access_token_secret=gR2txNle4eBod0I2MnpODqbL0H4SbGwvaubxoEqM6yqb5
ENV bearer_token=AAAAAAAAAAAAAAAAAAAAAFljQQEAAAAAIBPbUs4C7NQ9chasFgd%2BIkY%2Fbvs%3DWn3oja55MyfneShDKd9aL6EVvCDMczqOKvZmrEBYLdLZGIIjVz

RUN bundle install

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "src/tweet.LambdaFunction::Handler.process" ]