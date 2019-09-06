properties([    
    // Job parameter defintions.
    parameters([
        stringParam(
            description: 'Run Label - Defaults to scale and date',
            name: 'label',
            defaultValue: ''
        ),
        stringParam(
            description: 'Suffix to add to a schema name',
            name: 'name',
            defaultValue: ''
        ),
        stringParam(
            description: 'Hostname - Required if Url not specified',
            name: 'hostname',
            defaultValue: ''
        ),
        stringParam(
            description: 'Url - Required if Hostname not specified.',
            name: 'url',
            defaultValue: ''
        ),
        choiceParam(
            description: 'Benchmark',
            name: 'benchmark',
            choices: 'TPCH\nTPCDS\nTPCC\nHTAP'
        ),
        choiceParam(
            description: 'Scale',
            name: 'scale',
            choices: '1\n10\n100\n1000\n10000'
        ),
        choiceParam(
            description: 'Query Set',
            name: 'queryset',
            choices: 'good\nsnow\nall\nerrors\nerr'
        ),
        choiceParam(
            description: 'Mode for setup',
            name: 'mode',
            choices: 'bulk\nlinear'
        ),
        stringParam(
            description: 'Import data source',
            name: 'datasource',
            defaultValue: 's3a://splice-benchmark-data/flat/'
        ),
        stringParam(
            description: 'Log directory',
            name: 'logdir',
            defaultValue: '/logs'
        ),
        choiceParam(
            description: 'Iterations',
            name: 'iterations',
            choices: '1\n2\n3\n4\n5\n6\n7\n8\n9\n10'
        ),
        stringParam(
            description: 'Number of seconds to allow each query to run',
            name: 'timeout',
            defaultValue: 'forever'
        ),
        choiceParam(
            description: 'Force database creation',
            name: 'createdb',
            choices: 'no\nyes'
        ),
        choiceParam(
            description: 'Print debug messags',
            name: 'debug',
            choices: 'no\nyes'
        ),
        choiceParam(
            description: 'Print Verbose messages',
            name: 'verbose',
            choices: 'no\nyes'
        ),
        choiceParam(
            description: 'Print explain plans',
            name: 'explain',
            choices: 'no\nyes'
        )
    ])
])

def dockerargs = ''
def label = "${params.label}"
def name = "${params.name}"
def hostname = "${params.hostname}"
def url = "${params.url}"
def benchmark = "${params.benchmark}"
def scale = "${params.scale}"
def queryset = "${params.queryset}"
def mode = "${params.mode}"
def datasource = "${params.datasource}"
def logdir = "${params.logdir}"
def iterations = "${params.iterations}"
def timeout = "${params.timeout}"
def createdb = "${params.createdb}"
def debug = "${params.debug}"
def verbose = "${params.verbose}"
def explain = "${params.explain}"

dockerargs = '-i ' + iterations + ' -m ' + mode + ' -S ' + queryset + ' -b ' + benchmark + ' -s ' + scale + ' '

if( createdb == 'yes' ) {
    dockerargs = dockerargs + '-C '
}
if( debug == 'yes' ) {
    dockerargs = dockerargs + '-D '
}
if( verbose == 'yes' ) {
    dockerargs = dockerargs + '-V '
}
if( explain == 'yes' ) {
    dockerargs = dockerargs + '-P '
}
if (label) {
    dockerargs = '-l ' + label + ' '
}
if (name) {
    dockerargs = '-n ' + name + ' '
}
if (logdir) {
    dockerargs = '-L ' + logdir + ' '
}
if (datasource) {
    dockerargs = '-d ' + datasource + ' '
}
if (timeout) {
    dockerargs = '-t ' + timeout + ' '
}

// Launch the docker container
pipeline {
    agent {
        docker { 
            image 'splicemachine/benchmark:latest',
            args '${dockerargs}'
        }
    }
}